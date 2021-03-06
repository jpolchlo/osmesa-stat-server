package osmesa.server.model

import doobie._
import doobie.implicits._
import cats.effect._
import io.circe._
import io.circe.generic.semiauto._


case class User(
  id: Int,
  name: Option[String]
)


object User {

  implicit val userDecoder: Decoder[User] = deriveDecoder
  implicit val userEncoder: Encoder[User] = deriveEncoder

  private val selectF = fr"""
      SELECT
        id, name
      FROM
        users
    """

  def byId(id: Int)(implicit xa: Transactor[IO]): IO[Either[OsmStatError, User]] =
    (selectF ++ fr"WHERE id = $id")
      .query[User]
      .option
      .transact(xa)
      .map {
        case Some(user) => Right(user)
        case None => Left(IdNotFoundError("user", id))
      }

  def getPage(pageNum: Int)(implicit xa: Transactor[IO]): IO[ResultPage[User]] = {
    val offset = pageNum * 10 + 1
    (selectF ++ fr"ORDER BY id ASC LIMIT 10 OFFSET $offset")
      .query[User]
      .to[List]
      .map({ ResultPage(_, pageNum) })
      .transact(xa)
  }
}

